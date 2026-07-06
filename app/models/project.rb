class Project < ApplicationRecord
  ALLOWED_ROOTS = [
    File.expand_path("~/Sites"),
    File.expand_path("~/Developer")
  ].freeze

  has_many :deployment_runs, dependent: :destroy

  validates :root_path, presence: true, uniqueness: true
  validates :config_path, presence: true
  validate :root_path_must_exist
  validate :root_path_must_be_allowed
  validate :config_path_must_exist

  before_validation :normalize_paths
  before_validation :set_defaults_from_path

  def self.register!(root_path)
    expanded = File.expand_path(root_path)
    config_path = discover_config_path(expanded)
    raise ActiveRecord::RecordInvalid.new(new), "No deploy.yml found in #{expanded}" unless config_path

    find_or_initialize_by(root_path: expanded).tap do |project|
      project.config_path = config_path
      project.destinations = discover_destinations(expanded)
      project.last_synced_at = Time.current
      project.save!
    end
  end

  def self.discover_config_path(root)
    candidates = [
      File.join(root, "config", "deploy.yml"),
      File.join(root, "deploy.yml")
    ]
    candidates.find { |path| File.file?(path) }
  end

  def self.discover_destinations(root)
    Kamal::DestinationDiscovery.call(root)
  end

  def display_name
    name.presence || File.basename(root_path)
  end

  def config_relative_path
    Pathname.new(config_path).relative_path_from(Pathname.new(root_path)).to_s
  end

  def refresh!
    update!(
      destinations: self.class.discover_destinations(root_path),
      last_synced_at: Time.current
    )
  end

  def kamal_available?
    Kamal::CommandRunner.kamal_available?(self)
  end

  private

  def normalize_paths
    self.root_path = File.expand_path(root_path) if root_path.present?
    self.config_path = File.expand_path(config_path) if config_path.present?
  end

  def set_defaults_from_path
    return if root_path.blank?

    self.name ||= File.basename(root_path)
    self.config_path ||= self.class.discover_config_path(root_path)
    self.destinations = self.class.discover_destinations(root_path) if destinations.blank?
  end

  def root_path_must_exist
    return if root_path.blank?

    errors.add(:root_path, "must be an existing directory") unless File.directory?(root_path)
  end

  def root_path_must_be_allowed
    return if root_path.blank?

    allowed = ALLOWED_ROOTS.any? do |root|
      root_path == root || root_path.start_with?("#{root}/")
    end

    errors.add(:root_path, "must be under #{ALLOWED_ROOTS.join(' or ')}") unless allowed
  end

  def config_path_must_exist
    return if config_path.blank?

    errors.add(:config_path, "must exist") unless File.file?(config_path)
  end
end
