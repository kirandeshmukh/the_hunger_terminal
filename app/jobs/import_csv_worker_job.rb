class ImportCsvWorkerJob < ApplicationJob
  queue_as :default

  def perform(company_id, terminal_id, menu_items)
    message = nil
    header = []
    is_valid = true
    @company = Company.find company_id 
    @terminal = @company.terminals.find terminal_id
    @count_menu_items = @terminal.menu_items.count
    p @count_menu_items

    CSV.open("#{Rails.root}/public/#{@terminal.name}-invalid_records.csv","w") do |csv|
      CSV.parse(menu_items.to_s,headers: true) do |row|
    
        next if row.to_a == ["name","price","veg","description","active_days"]
       
        active_days = '{' + "#{row['active_days']}" + '}' 

        @menu_item = @terminal.menu_items.find_or_initialize_by(name: row['name'],price: row['price'],veg: row['veg'],description: row['description'],active_days: active_days)

        if !@menu_item.save 

          is_valid = false
          @menu_item.errors.to_a.each do |error|
            row << error
          end
          csv << row
        else
          @menu_item.save
        end 
      end
    end

    if is_valid == false
      message = "Some Records are Invalid! Click Invalid Records CSV to download file!!!"

    else
      message = "Records Uploaded!"
    end

    return message
  end
end
