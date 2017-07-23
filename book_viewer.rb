require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  not_found unless number.between?(1, 12)
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    chapter = File.read("data/chp#{number}.txt")
    yield number, name, chapter
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, chapter|
    matches = {}
    chapter.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
      results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(chapter)
    chapter.split("\n\n").map.with_index do |par, index| 
      "<p id=p#{index + 1}>#{par}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end