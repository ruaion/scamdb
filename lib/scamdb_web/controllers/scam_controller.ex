defmodule ScamdbWeb.ScamController do
  use ScamdbWeb, :controller
  use ScamdbWeb, :model
  require Logger

  alias Scamdb.Scam
  alias Scamdb.Repo

  def index(conn, %{"query" => query}) do
    query = from u in Scam,
              select: u,
              where: ilike(u.full_name, ^"#{query}%") 
              or u.phone == ^query
              or u.email == ^query
              or u.bank_account == ^query
              or u.passport == ^query

    scammers = Repo.all(query)
    render(conn, "index.json", scammers: scammers)
  end

  def create(conn, %{"scammer" => scammer_params}) do
    remote_ip = conn.get_req_header(conn, "x-forwarded-for")
                |> Tuple.to_list
                |> Enum.join(".")
    scammer_params = Map.put_new(scammer_params, "ip", remote_ip)
    changeset = Scam.changeset(%Scam{}, scammer_params)
    case Repo.insert(changeset) do
      {:ok, scammer} ->
        conn
        |> put_status(:created)
#        |> put_resp_header("location", scammer_path(conn, :show, scammer))
        |> render("show.json", scammer: scammer)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Scamdb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    scammer = Repo.get!(Scam, id)
    render(conn, "show.json", scammer: scammer)
  end

  def update(conn, %{"id" => id, "scammer" => scammer_params}) do
    scammer = Repo.get!(Scam, id)
    changeset = Scam.changeset(scammer, scammer_params)

    case Repo.update(changeset) do
      {:ok, scammer} ->
        render(conn, "show.json", scammer: scammer)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Scamdb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    scammer = Repo.get!(Scam, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(scammer)

    send_resp(conn, :no_content, "")
  end
end