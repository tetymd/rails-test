class ArticlesController < ApplicationController
  before_action :set_ranking

  def index
  end

  def show
    @article = Article.find(params[:id])
    REDIS.zincrby "articles/daily/#{Date.today.to_s}", 1, "#{@article.id}"
  end

  def set_ranking_data
    #５件のランキングデータを取得
    ids = REDIS.zrevrangebyscore "articles/daily/#{Date.today.to_s}", "+inf", 0, limit: [0, 5]
    @ranking_articles = Article.where(id: ids)

     #５件未満の場合、公開日時順で値を取得
    if @ranking_articles.count < 5
      adding_articles = Article.order(publish_time: :DESC, updated_at: :DESC).where.not(id: ids).limit(5 - @ranking_articles.count)
      @ranking_articles.concat(adding_articles)
    end
  end
end
