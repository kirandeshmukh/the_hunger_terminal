require "test_helper"

class UserTest < ActiveSupport::TestCase

  before :each do
    DatabaseCleaner.start
    # DatabaseCleaner.clean
    @user = build(:user)
  end

  #Devise automatically validates email. Thus, no need to write validation for it.

  test "name must be present" do
    @user.name = nil
    @user.valid?
    assert @user.errors[:name].include?("can't be blank")
  end

  test "mobile number must be present" do 
    @user.mobile_number = nil
    @user.valid?
    assert @user.errors[:mobile_number].include?("can't be blank")

  end

  test "role must be present" do
    @user.role = nil
    @user.valid?
    assert @user.errors[:role].include?("can't be blank")
  end

  test "should have valid indian mobile number" do
   @user.mobile_number = "123ABC890"
    @user.valid?
    assert @user.errors[:mobile_number].include?("Enter valid mobile no.")
  end

  test "mobile number should have 10 characters " do
    @user.mobile_number = "123"
    @user.valid?
    assert @user.errors[:mobile_number].include?("is the wrong length (should be 10 characters)")
  end 

  test "role must have value from given array" do
    @user.role = "dummy"
    @user.valid?
    assert @user.errors[:role].include?("is not included in the list")
  end

  test "is_active must have a boolean value" do
    @user.is_active = "dummy"
    @user.valid?
    assert @user.errors[:is_active].include?("This must be true or false.")
  end


  test "user email should be unique in a company" do
    @company = create(:company)
    @employee = @company.employees.first
    @duplicate_employee = build(:user)
    @duplicate_employee.company_id = @company.id
    @duplicate_employee.email = @employee.email
    @duplicate_employee.valid?
    assert @duplicate_employee.errors[:email].include?("user email should be unique in a company")
  end

  test "user mobile number must be unique in a company" do
    @company = create(:company)
    @employee = @company.employees.first
    @duplicate_employee = build(:user)
    @duplicate_employee.company_id = @company.id
    @duplicate_employee.mobile_number = @employee.mobile_number
    @duplicate_employee.valid?
    assert @duplicate_employee.errors[:mobile_number].include?("user mobile number should be unique in a company") 
  end

  test "company must be present for an employee" do
    @user.role = "employee"
    @user.company = nil
    @user.valid?
    assert @user.errors[:company].include?("can't be blank")
  end

  test "employees' running balance report should be generated" do
    user = create(:user_with_orders)
    user.orders.each do |order|
      order = nil
    end
    company_id = user.company_id
    p company_id
    user2 = build(:user)
    user2.company_id = company_id
    user2.save!
    p user2.errors
    report = User.employee_report(company_id)
    assert_equal report, []
  end

  test "employees' today's report should be generated" do
  user1 = create(:user) # created an user who don't have order for today
  company_id = user1.company_id
  user2 = build(:user)
  user2.company_id = company_id
  user2.save!
  report = User.employees_todays_orders_report(company_id)
  assert_equal report, []
  end

  test "employees' last month report should be generated" do
    user = create(:user) # created an user who don't have any last month report
    company_id = user.company_id
    user2 = build(:user)
    user2.company_id = company_id
    user2.save!
    report = User.employee_last_month_report(company_id, Time.now - 1.month)
    assert_equal report, []
  end

  test "individual employee's last month report should be generated" do
    user = create(:user) # created an user who don't have any last month report
    company_id = user.company_id
    report = User.employee_last_month_report(company_id, user.id)
    assert_equal report, []
  end


end
