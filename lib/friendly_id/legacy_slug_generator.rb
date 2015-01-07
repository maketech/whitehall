# Copyright (c) 2008-2014 Norman Clarke, Adrian Mugnolo and Emilio Tagua.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
module FriendlyId
  # Lifted wholesale from friendly_id 4.0.9 (where it is simply SlugGenerator).
  #
  # We want to maintain the v4 slug generation behaviour that adds a sequence
  # number to clashing slugs when upgrading to newer versions of friendly_id
  # (specifically when upgrading to v5 for Rails 4 support - v5 removes the
  # sequence behaviour and replaces it with GUIDs instead)
  class LegacySlugGenerator
    attr_reader :sluggable, :normalized

    # Create a new slug generator.
    def initialize(sluggable, normalized)
      @sluggable  = sluggable
      @normalized = normalized
    end

    # Given a slug, get the next available slug in the sequence.
    def next
      "#{normalized}#{separator}#{next_in_sequence}"
    end

    # Generate a new sequenced slug.
    def generate
      conflict? ? self.next : normalized
    end

    private

    def next_in_sequence
      last_in_sequence == 0 ? 2 : last_in_sequence.next
    end

    def last_in_sequence
      @_last_in_sequence ||= extract_sequence_from_slug(conflict.to_param)
    end

    def extract_sequence_from_slug(slug)
      slug.split("#{normalized}#{separator}").last.to_i
    end

    def column
      sluggable.connection.quote_column_name friendly_id_config.slug_column
    end

    def conflict?
      !! conflict
    end

    def conflict
      unless defined? @conflict
        @conflict = conflicts.first
      end
      @conflict
    end

    def conflicts
      sluggable_class = friendly_id_config.model_class.base_class

      pkey  = sluggable_class.primary_key
      value = sluggable.send pkey
      base = "#{column} = ? OR #{column} LIKE ?"
      # Awful hack for SQLite3, which does not pick up '\' as the escape character without this.
      base << "ESCAPE '\\'" if sluggable.connection.adapter_name =~ /sqlite/i
      scope = sluggable_class.unscoped.where(base, normalized, wildcard)
      scope = scope.where("#{pkey} <> ?", value) unless sluggable.new_record?
      scope = scope.order("LENGTH(#{column}) DESC, #{column} DESC")
    end

    def friendly_id_config
      sluggable.friendly_id_config
    end

    def separator
      friendly_id_config.sequence_separator
    end

    def wildcard
      # Underscores (matching a single character) and percent signs (matching
      # any number of characters) need to be escaped
      # (While this seems like an excessive number of backslashes, it is correct)
      "#{normalized}#{separator}".gsub(/[_%]/, '\\\\\&') + '%'
    end
  end
end
