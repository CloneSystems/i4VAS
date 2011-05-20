class Task

  include BasicModel

  # note: since we are not using ActiveRecord for persistence, but ActiveModel instead, 
  #       we need to manually manipulate the return value for "persisted?" so that in 
  #       the views "form_for" will set the correct route and post/put action 
  #       ... i.e. use false for new/create actions, and true for edit/update actions:
  attr_accessor :persisted

  attr_accessor :id, :name, :comment, :status, :trend, :config_id, :config_name, :target_id, :target_name, :overall_progress

  validates :comment, :length => { :maximum => 400 }
  validates :name, :presence => true, :length => { :maximum => 80 }
  # {:name=>["can't be blank"]}
  # - Name can't be blank
  # ... openvas error:
  # {:command_failure=>
  # ["
  # Command Failed: Too few parameters\n
  # Command Status: 400\n
  # Command: <?xml version=\"1.0\"?>\n
  # <modify_task task_id=\"d9cc368c-2011-4871-be47-737e6b07a1e7\">\n 
  # <name></name>\n 
  # <comment></comment>\n
  # </modify_task>\n\n
  # Response: <?xml version=\"1.0\"?>\n
  #   <modify_task_response status=\"400\" status_text=\"Too few parameters\"/>\n
  # "]}

  def persisted?
    @persisted || false
  end

  def self.all
    tasks = []
    OpenvasCli::VasTask.get_all.each do |vt|
      cfg = OpenvasCli::VasConfig.get_by_id(vt.config_id)
      trg = OpenvasCli::VasTarget.get_by_id(vt.target_id)
      progress = vt.progress
      tasks << Task.new({ :id => vt.id, :name => vt.name, :comment => vt.comment, :status => vt.status,
                          :trend => vt.trend, :overall_progress => progress.overall,
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
    return nil if id.blank?
    OpenvasCli::VasTask.get_by_id(id)
  end

  def save
    if valid?
      vt = Task.find_as_vastask(self.id) # for update action
      vt = OpenvasCli::VasTask.new if vt.blank? # for create action
      vt.name = self.name
      vt.comment = self.comment
      # note: openvas doesn't allow updates to config_id and target_id, only name and comment:
      if vt.new_record?
        vt.config_id = self.config_id
        vt.target_id = self.target_id
      end
      vt.create_or_update
      vt.errors.each do |attribute, msg|
        self.errors.add(:openvas, "<br />" + msg)
      end
      return false unless self.errors.blank?
      return true
    else
      return false
    end
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