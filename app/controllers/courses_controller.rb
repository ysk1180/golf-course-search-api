class CoursesController < ApplicationController
  def search
    date = params['date']
    budget = params['budget']
    departure = params['departure']
    duration = params['duration'].to_i

    RakutenWebService.configure do |c|
      c.application_id = ENV['RAKUTEN_APPID']
      c.affiliate_id = ENV['RAKUTEN_AFID']
    end

    courses = RakutenWebService::Gora::Plan.search(maxPrice: budget, playDate: date, areaCode: '11,12,13,14', sort: 'evaluation')
    course_names = courses.map { |course| course['golfCourseName'] }

    gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_MAP_API_KEY'])

    matched_courses_names = []
    course_names.each do |name|
      routes = gmaps.directions(
        departure,
        name,
      )
      duration_seconds = routes.first[:legs][0][:duration][:value]
      duration_minutes = duration_seconds / 60
      if duration_minutes < duration
        matched_courses_names << name
        break if matched_courses_names.size >= 5
      end
    end

    render json: { course_names: matched_courses_names }
  end
end
