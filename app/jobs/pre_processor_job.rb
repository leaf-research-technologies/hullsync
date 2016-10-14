require 'helpers'
class PreProcessorJob
  @queue = :pre_processor

  def self.perform(folder_id, original_filename)
    puts '2. ----------------------------------'
    puts 'In pre processor'
    box_client = BoxClient.new
    # Get folder metadata
    folder = box_client.folder_from_id(folder_id)
    # Copy data locally
    box_user_dir = File.join(ENV['BOX_ROOT_DIR'], folder.name)
    new_name = folder.name
    if new_name.end_with?('_processing')
      new_name.gsub!(/(.*)(_processing)(.*)/, '\1\3')
    end
    bagit_content_dir = File.join(ENV['BAGIT_ROOT_DIR'], new_name, 'content')
    bagit_admin_dir = File.join(ENV['BAGIT_ROOT_DIR'], new_name, 'admin')
    if copy_folder(box_user_dir, bagit_content_dir)
      # Create metadata file for bagit
      metadata = {
          depositor_name: folder.created_by.name,
          depositor_email: folder.created_by.login,
          date_created: folder.created_at,
          ingest_route: 'box',
          original_name: original_filename
      }
      create_bagit_metadata_files(bagit_content_dir, bagit_admin_dir, metadata)
      Resque.enqueue(InformUserJob, folder_id, original_filename, metadata)
      Resque.enqueue(ArchiveProcessorJob, bagit_content_dir)
    end
  end

end

