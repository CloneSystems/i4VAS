class ScanTarget

  include BasicModel

  attr_accessor :persisted

  attr_accessor :id, :name, :comment, :hosts, :port_range, :in_use

  validates :name, :presence => true

  def persisted?
    @persisted || false
  end

  def self.all
    []
  end

  def self.find(args)
  end

  def self.selections
    targets = []
    OpenvasCli::VasTarget.get_all.each do |t|
      targets << ScanTarget.new({ :id => t.id, :name => t.name })
    end
    targets
  end

  def save
    valid? ? true : false
  end

  def update_attributes(attrs={})
    attrs.each { |key, value|
      send("#{key}=".to_sym, value) if public_methods.include?("#{key}=".to_sym)
    }
    save
  end

  def destroy
    delete_record
  end

  def self.get_by_id(id)
    get_all(:id => id).first
  end

  def create_or_update
    true
  end

  def delete_record
    true
  end

end