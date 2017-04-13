class Racer

  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

  def initialize(params={})
    @id = [:_id].nil? ? params[:id] : params[:_id].to_s
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i
  end


  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    self.mongo_client['racers']
  end

  def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)
    result = self.collection.find(prototype)
                 .sort(sort)
                 .skip(skip)
    result = result.limit(limit) if !limit.nil?
    return result
  end

  def self.find id
    id = (id.is_a? BSON::ObjectId) ? id : BSON::ObjectId.from_string(id)
    result = self.collection.find(:_id=>id).first
    return result.nil? ? nil : Racer.new(result)
  end

  def save
    result = self.class.collection.insert_one(
      number: @number,
      first_name: @first_name,
      last_name: @last_name,
      gender: @gender,
      group: @group,
      secs: @secs)
    @id = result.inserted_id.to_s
  end

  def update(params)
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i
    params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)

    self.class.collection
              .find(_id:BSON::ObjectId.from_string(@id))
              .update_one(params)
  end

end
