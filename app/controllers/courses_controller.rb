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

    courses = RakutenWebService::Gora::Plan.search(maxPrice: budget, playDate: date, areaCode: '11,12,13,14', sort: 'evaluation', NGPlan: 'planHalfRound')

    gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_MAP_API_KEY'])

    matched_courses = []
    courses.each do |course|
      routes = gmaps.directions(
        departure,
        course['golfCourseName'],
      )
      duration_seconds = routes.first[:legs][0][:duration][:value]
      duration_minutes = duration_seconds / 60
      if duration_minutes < duration && course['planInfo'].present? && course['golfCourseName'] !~ /ショート/ && course['golfCourseCaption'] !~ /ショート/ && course['planInfo'][0]['planName'] !~ /ショート/ && course['planInfo'][0]['planName'] !~ /7ホール/ && course['planInfo'][0]['planName'] !~ /ナイター/
        matched_courses.push(
          {
            name: course['golfCourseName'],
            caption: course['golfCourseCaption'],
            prefecture: course['prefecture'],
            image_url: course['golfCourseImageUrl'],
            evaluation: course['evaluation'],
            plan_name: course['planInfo'][0]['planName'],
            price: course['planInfo'][0]['price'],
            reserve_url_pc: course['planInfo'][0]['callInfo']['reservePageUrlPC'],
            reserve_url_mobile: course['planInfo'][0]['callInfo']['reservePageUrlMobile'],
            duration: duration_minutes,
          }
        )
        break if matched_courses.size >= 2
      end
    end

    render json: { courses: matched_courses }
  end
end
