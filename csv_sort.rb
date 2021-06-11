require 'csv'

@headers = nil
@insurance_companies = {}

CSV.foreach("enrollments.csv", headers: true, header_converters: :symbol) do |enrollment|
  @headers ||= enrollment.headers
  company_name = enrollment[:insurance_company]
  user_id = enrollment[:user_id];
  company = @insurance_companies[company_name]
  if company.nil?
    @insurance_companies[company_name] = {user_id=>enrollment}
  else
    company_enrollment = company[user_id]
    if company_enrollment.nil?
      company[user_id] = enrollment
    else
      company[user_id] = company_enrollment[:version].to_i > enrollment[:version].to_i ? company_enrollment : enrollment
    end
  end
end


@insurance_companies.each do |company_name, enrollments|
  CSV.open("out/#{company_name}.csv", "w") do |csv|
    csv << @headers
    enrollments.sort_by { |user_id, enrollment| enrollment[:first_last_name] }.each do |item|
      csv << item[1] #index 0 = key; index 1 = value
    end
  end
end