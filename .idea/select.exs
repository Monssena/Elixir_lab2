# Подгрузка необходимых пакетов.
Mix.install([:myxql, :plug, :plug_cowboy])

# Модуль для работы с базой данных.
defmodule ExDataBase do
  def init_conn() do
    children = [{MyXQL, hostname: "127.0.0.1", username: "root", password: "Lvbnhbq2001", database: "test", name: :mydb}]
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init(sQuery) do
    init_conn()
    {:ok, result} = MyXQL.query(:mydb, sQuery)
    result
  end

  def call_procedure(table1, table2) do
    init_conn()
    query = "CALL proc1(?, ?)"
    {:ok, result} = MyXQL.query(:mydb, query, [table1, table2])
    result
  end

  # Функция для вставки данных в таблицу.
  def if_param_insert(s1, s2, s3) do
    if s1 != nil and s2 != nil and s3 != nil do
      init_conn()
      {:ok, result} = MyXQL.query(:mydb, "INSERT INTO objects (type, accuracy, quantity) VALUES (?, ?, ?)", [s1, s2, s3])
      ExDataBase.log("User added 1 row to table objects")
      result
    end
  end

  # Окружить тегом одной ячейки <td> ... </td>.
  def btwTagTd(s, sDop) do
    sDop <> "<td>" <> to_string(s) <> "</td>"
  end

  # Окружить тегом одной строки <tr> ... </tr>.
  def btwTagTr(s1, sDop) do
    sDop1 = Enum.map(s1, fn s -> ExDataBase.btwTagTd(s, sDop) end)
    "<tr>" <> to_string(sDop1) <> "</tr>"
  end

  # Разделение массива на отдельные строки.
  def sepRows(s1, sDop) do
    sDop <> ExDataBase.btwTagTr(s1, sDop)
  end

  # Возвращение заголовка с тегами HTML.
  def columns(result) do
    sDop1 = ""
    sDop1 = Enum.map(result.columns, fn s -> ExDataBase.btwTagTd(s, sDop1) end)
    "<tr>" <> to_string(sDop1) <> "</tr>"
  end

  # Возвращение всех строк SELECT с тегами HTML.
  def rows(result) do
    sDop2 = ""
    Enum.map(result.rows, fn s -> ExDataBase.sepRows(s, sDop2) end)
  end

  def get_sectors() do
    result = call_procedure("Sectors", "Sectors")
    to_string(columns(result)) <> Enum.join(rows(result))
  end

  # Проверка на ключевое слово в файле select.html и возврат заголовка с тегами <tr><td> ... </td></tr> для одной строки в таблице HTML.
  def if_columns(s1, s2) do
    if s1 =~ s2 do
      result = call_procedure("Sectors", "Sectors")
      to_string(ExDataBase.columns(result))
    end
  end

  # То же самое, но для строк таблицы.
  def if_rows(s1, s2) do
    if s1 =~ s2 do
      result = call_procedure("Sectors", "Sectors")
      to_string(ExDataBase.rows(result))
    end
  end

  # Возврат всего одной ячейки, версии базы данных (БД).
  def if_one_row(s1, s2) do
    if s1 =~ s2 do
      result = ExDataBase.init("SELECT VERSION() AS ver")
      a1 = Enum.map(result.rows, fn s -> s end)
      to_string(a1)
    end
  end

  # Отображение событий от пользователей из браузера на экран.
  def log(sLine) do
    IO.puts to_string(NaiveDateTime.utc_now) <> " Event: " <> sLine
  end
end

# Модуль для работы из браузера.
defmodule MyPlug do
  use Plug.Router
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :dispatch

  get "/search" do
    IO.puts "/search is ok."
    fetch_query_params(conn)
  end

  def call(conn, _opts) do
    conn1 = fetch_query_params(conn)
    col1 = conn1.params["col1"]
    col2 = conn1.params["col2"]
    col3 = conn1.params["col3"]

    ExDataBase.if_param_insert(col1, col2, col3)
    {:ok, file} = File.open("select.html", [:read, :utf8])
    put_resp_content_type(conn, "text/html")
    sText = ""
    send_resp(conn, 200, read_file(file, sText))
  end

  def plusSrt(s1, a1) do
    s1 <> to_string(a1)
  end

  def plusSrtExcept(sMain, sNew, sTag1, sTag2) do
    if sNew =~ sTag1 || sNew =~ sTag2 do
      sMain
    else
      sMain <> sNew
    end
  end

  def read_file(file, sText) do
    aLine = IO.read(file, :line)
    stLine = to_string(aLine)
    if aLine != :eof do
      sText = plusSrtExcept(sText, stLine, "@tr", "@ver")
      aLine2 = ExDataBase.if_columns(stLine, "@tr")
      sText = plusSrt(sText, aLine2)
      aLine2 = ExDataBase.if_rows(stLine, "@tr")
      sText = plusSrt(sText, aLine2)
      aLine2 = ExDataBase.if_one_row(stLine, "@ver")
      sText = plusSrt(sText, aLine2)
      read_file(file, sText)
    else
      ExDataBase.log("The user got a select.html page")
      sText
    end
  end
end

require Logger
webserver = {Plug.Cowboy, plug: MyPlug, scheme: :http, options: [port: 4000]}
{:ok, _} = Supervisor.start_link([webserver], strategy: :one_for_one)
Logger.info("Plug now running on http://localhost:4000/")
Process.sleep(:infinity)
