FriendlyId.defaults do |config|
  config.base = :name
  config.use :slugged, Slugging
  config.slug_generator_class = FriendlyId::LegacySlugGenerator
end
