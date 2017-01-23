require 'box_client'
class InformUserJob
  @queue = :inform_user

  def self.perform(folder_id, original_filename, metadata, status)
    puts '3. ---------------------------'
    puts 'Inform user'
    puts folder_id
    puts original_filename
    puts metadata
    box_client = BoxClient.new
    # Get folder metadata
    folder = box_client.folder_from_id(folder_id)
    # Rename folder
    box_client.rename_folder(folder, original_filename, status=status)
    # Remove collaboration
    box_client.remove_my_collaboration(folder)
  end
end
