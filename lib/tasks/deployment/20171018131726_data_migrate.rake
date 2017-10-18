namespace :after_party do
  desc 'Deployment task: data_migrate'
  task data_migrate: :environment do
    puts "Running deploy task 'data_migrate'"

    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20171018131726'
  end  # task :data_migrate
end  # namespace :after_party
