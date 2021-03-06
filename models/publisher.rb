require_relative('../db/sql_runner.rb')

class Publisher

  attr_accessor :name, :active
  attr_reader :id

  def initialize(publisher)
    @id = publisher['id'].to_i if publisher['id']
    @name = publisher['name']
    @active = publisher['active']
  end

  def save()
    sql = "INSERT INTO publishers (name, active) VALUES ($1, $2) RETURNING id"
    values = [@name, @active]
    results = SqlRunner.run(sql, values)
    @id = results.first()['id'].to_i
  end

  def update()
    sql = "UPDATE publishers SET (name, active) = ($1, $2) WHERE id = $3"
    values = [@name, @active, @id]
    return SqlRunner.run(sql,values)
  end

  def delete()
    sql = "DELETE FROM publishers WHERE id = $1"
    values = [@id]
     return SqlRunner.run(sql,values)
  end

  def self.all()
    sql = "SELECT * FROM publishers"
    all = SqlRunner.run(sql)
    return all.map{|publisher| Publisher.new(publisher)}
  end

  def self.delete_all()
    sql = "DELETE FROM publishers"
    SqlRunner.run(sql)
  end

  def self.find_by_publisher_id(publisher_id)
    sql = "SELECT * FROM publishers WHERE id = $1"
    values = [publisher_id]
    publishers = SqlRunner.run(sql,values).first
    return nil if publishers == nil
    return Publisher.new(publishers)
  end

  def all_the_genre_by_publisher()
    sql ="SELECT DISTINCT genres.* FROM genres
          INNER JOIN books
          ON books.genre_id = genres.id
          WHERE books.publisher_id = $1"
    values = [@id]
    genres = SqlRunner.run(sql,values)
    return genres.map{|genre| Genre.new(genre)}
  end

  def all_the_authors_by_publisher()
    sql = "SELECT DISTINCT authors.* FROM authors
          INNER JOIN books
          ON authors.id = books.author_id
          WHERE books.publisher_id = $1"
    values = [@id]
    authors = SqlRunner.run(sql,values)
    return authors.map{|author| Author.new(author)}
  end

  def self.all_the_books_by_publisher(publisher_id)
    sql = "SELECT DISTINCT books.* FROM books
          INNER JOIN genres
          ON genres.id = books.genre_id
          WHERE books.publisher_id = $1"
    values = [publisher_id]
    books = SqlRunner.run(sql,values)
    return books.map{|book| Book.new(book)}
  end

  def active_publisher?()
    return true if @active == "t"
    return false if @active == "f"
  end

  def find_book_by_author_id(author_id)
    sql = "SELECT books.* FROM books
            INNER JOIN publishers
            ON publishers.id = books.publisher_id
            INNER JOIN authors
            ON authors.id = books.author_id
            WHERE books.publisher_id = $1 AND books.author_id = $2"
    values = [@id, author_id]
    books = SqlRunner.run(sql,values)
    return books.map {|book| Book.new(book)}
  end

  def find_book_by_genre_id(genre_id)
    sql = "SELECT books.* FROM books
            INNER JOIN publishers
            ON publishers.id = books.publisher_id
            WHERE books.publisher_id = $1 AND books.genre_id = $2"
    values = [@id, genre_id]
    books = SqlRunner.run(sql,values)
    return books.map {|book| Book.new(book)}
  end


end
