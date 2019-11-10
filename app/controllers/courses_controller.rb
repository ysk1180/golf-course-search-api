class CoursesController < ApplicationController
  def search
    budget = params['query']

    RakutenWebService.configure do |c|
      c.application_id = ENV['RAKUTEN_APPID']
      c.affiliate_id = ENV['RAKUTEN_AFID']
    end

    courses = RakutenWebService::Gora::Plan.search(maxPrice: budget, playDate: '2019-11-15', areaCode: '11,12,13,14', sort: 'evaluation')
    course_names = courses.map { |course| course['golfCourseName'] }

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
