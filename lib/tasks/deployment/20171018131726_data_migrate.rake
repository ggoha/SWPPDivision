namespace :after_party do
  def create_company
    Company.create(icon: '', title: '')
    Company.create(icon: '', title: '')
    Company.create(icon: '', title: '')
    Company.create(icon: '', title: '')
    Company.create(icon: '', title: '')
  end

  def create_default_division
    Company.all.each do |c|
      c.divisions.create(title: 'Main ' + c.title)
    end
  end

  def import_battles
    ActiveRecord::Base.establish_connection('all_development')
    battles = Battle.all
    ActiveRecord::Base.establish_connection('development')
    battles.each do |battle|
      
    end
  end

  def import_stocks
    ActiveRecord::Base.establish_connection('all_development')
    stocks = Stock.all
    ActiveRecord::Base.establish_connection('development')
    stocks.each do |stock|
      Stock.create(stock)
    end
  end

  def import_users
    ActiveRecord::Base.establish_connection('all_development')
    users = User.all
    ActiveRecord::Base.establish_connection('development')
    users.each do |user|
      User.create(user)
    end
  end

  def imports_reports
    ActiveRecord::Base.establish_connection('all_development')
    reports = Reports.all
    ActiveRecord::Base.establish_connection('development')
    reports.each do |report|
      r = report.attributes
      r['comrades_percentage'] = r['buff']
      r.delete('buff')
      r['battle_result_id'] = r['battle_id']
      r.delete('battle_id')
      User.create(r)
    end
  end

  desc 'Deployment task: data_migrate'
  task data_migrate: :environment do
    puts "Running deploy task 'data_migrate'"

    # Put your task implementation HERE.
    create_company
    create_default_division
    import_battles
    import_stocks
    import_users
    import_reports
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20171018131726'
  end  # task :data_migrate
end  # namespace :after_party
