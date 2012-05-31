class Document < ActiveRecord::Base
  set_table_name :documents

  extend FriendlyId
  friendly_id :sluggable_string, use: :scoped, scope: :document_type

  after_destroy :destroy_all_editions
  has_many :editions
  has_many :edition_relations, dependent: :destroy
  has_one :published_edition, class_name: 'Edition', conditions: { state: 'published' }
  has_one :unpublished_edition, class_name: 'Edition', conditions: { state: ['draft', 'submitted', 'rejected'] }

  has_many :consultation_responses, class_name: 'ConsultationResponse', foreign_key: :consultation_document_id, dependent: :destroy
  has_one :published_consultation_response, class_name: 'ConsultationResponse', foreign_key: :consultation_document_id, conditions: { state: 'published' }

  has_one :latest_edition, class_name: 'Edition', conditions: "NOT EXISTS (SELECT 1 FROM editions e2 WHERE e2.document_id = editions.document_id AND e2.id > editions.id AND e2.state <> 'deleted')"

  attr_accessor :sluggable_string

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def unpublished_edition
    editions.where("state IN (:draft_states)", draft_states: [:draft, :submitted, :rejected]).first
  end

  def editions_ever_published
    editions.where(state: [:published, :archived]).by_published_at
  end

  def update_slug_if_possible(new_title)
    unless published?
      self.sluggable_string = new_title
      save
    end
  end

  def set_document_type(document_type)
    self.document_type = document_type
  end

  def published?
    published_edition.present?
  end

  class << self
    def published
      joins(:published_edition)
    end
  end

  private

  def destroy_all_editions
    Edition.unscoped.destroy_all(document_id: self.id)
  end
end
