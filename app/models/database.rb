# frozen_string_literal: true

class Database < ApplicationRecord
  belongs_to :user
  enum dbms_type: { sqlite: 0 }
  mount_uploader :avatar, FileUploader
end
