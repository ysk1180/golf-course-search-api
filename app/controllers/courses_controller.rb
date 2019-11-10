class CoursesController < ApplicationController
  def search
    date = params['date']
    budget = params['budget']
    departure = params['departure']

    RakutenWebService.configure do |c|
      c.application_id = ENV['RAKUTEN_APPID']
      c.affiliate_id = ENV['RAKUTEN_AFID']
    end

    courses = RakutenWebService::Gora::Plan.search(maxPrice: budget, playDate: date, areaCode: '11,12,13,14', sort: 'evaluation')
    course_names = courses.map { |course| course['golfCourseName'] }

    p departure
    p date
    # gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_MAP_API_KEY'])
    #
    # routes = gmaps.directions(
    #   '二子玉川駅',
    #   'そうぶファミリーゴルフ',
    # )
    # p routes.first[:legs][0][:duration][:text]

    render json: { course_names: course_names }
  end
end
