class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    
    domain = value.split('@').last
    unless options[:in].include?(domain)
      record.errors.add(attribute, "は許可された大学のメールアドレスである必要があります")
    end
  end
end 