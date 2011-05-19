class Task

  include BasicModel

  attr_accessor :persisted

  attr_accessor :id, :name, :comment, :config_id, :target_id
  attr_accessor :config_name, :target_name, :status

  validates :name, :presence => true, :length => { :maximum => 80 }
  validates :comment, :length => { :maximum => 400 }

  def persisted?
    @persisted || false
  end

  def self.all
    tasks = []
    OpenvasCli::VasTask.get_all.each do |vt|
      cfg = OpenvasCli::VasConfig.get_by_id(vt.config_id)
      trg = OpenvasCli::VasTarget.get_by_id(vt.target_id)
      tasks << Task.new({ :id => vt.id, :name => vt.name, :comment => vt.comment, :status => vt.status,
                          :config_id => vt.config_id, :target_id => vt.target_id,
                          :config_name => cfg.name, :target_name => trg.name
                       })
    end
    tasks
  end

  def self.find(id)
    vt = OpenvasCli::VasTask.get_by_id(id)
    cfg = OpenvasCli::VasConfig.get_by_id(vt.config_id)
    trg = OpenvasCli::VasTarget.get_by_id(vt.target_id)
    Task.new({:id => vt.id, :name => vt.name, :comment => vt.comment, 
              :config_id => vt.config_id, :target_id => vt.target_id,
              :config_name => cfg.name, :target_name => trg.name
            })
  end

  def self.find_as_vastask(id)
    OpenvasCli::VasTask.get_by_id(id)
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