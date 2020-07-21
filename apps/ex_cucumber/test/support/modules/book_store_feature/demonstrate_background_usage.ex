defmodule Support.BookStoreFeature.DemonstrateBackgroundUsage do
  use ExCucumber
  @feature "book_store.feature"

  defmodule BookStore do
    def find_by_author(books, author) do
      books
      |> Enum.filter(fn e ->
        match?(%{"author" => ^author}, e)
      end)
    end

    def find_by_title(books, title) do
      books
      |> Enum.filter(fn e ->
        match?(%{"title" => ^title}, e)
      end)
    end
  end

  Given._ "I have the following books in the store", args do
    {:ok, %{books: args.data_table}}
  end

  # Scenario: Find books by author
  # Scenario: Find books by author, but isn't there
  When._ "I search for books by author {author}", args do
    author = Keyword.fetch!(args.params, :author)
    results = BookStore.find_by_author(args.state.books, author)
    {:ok, %{results: results}}
  end

  Then._ "I find {int} books", args do
    expected_amount = Keyword.fetch!(args.params, :int)
    assert expected_amount == Enum.count(args.state.results)
  end

  # Scenario: Find book by title
  # Scenario: Find book by title, but isn't there
  When._ "I search for a book titled {title}", args do
    title = Keyword.fetch!(args.params, :title)
    results = BookStore.find_by_title(args.state.books, title)
    {:ok, %{results: results}}
  end

  Then._ "I find a book", args do
    assert Enum.count(args.state.results) > 0
  end

  Then._ "I find no book", args do
    assert Enum.count(args.state.results) == 0
  end
end
