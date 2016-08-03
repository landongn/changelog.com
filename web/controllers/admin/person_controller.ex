defmodule Changelog.Admin.PersonController do
  use Changelog.Web, :controller

  alias Changelog.Person

  plug :scrub_params, "person" when action in [:create, :update]

  def index(conn, params) do
    page = Person
    |> order_by([p], desc: p.id)
    |> Repo.paginate(params)

    render conn, :index, people: page.entries, page: page
  end

  def new(conn, _params) do
    changeset = Person.changeset(%Person{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, params = %{"person" => person_params}) do
    changeset = Person.changeset(%Person{}, person_params)

    case Repo.insert(changeset) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "#{person.name} created!")
        |> smart_redirect(person, params)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)
    changeset = Person.changeset(person)
    render(conn, "edit.html", person: person, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "person" => person_params}) do
    person = Repo.get!(Person, id)
    changeset = Person.changeset(person, person_params)

    case Repo.update(changeset) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "#{person.name} udated!")
        |> smart_redirect(person, params)
      {:error, changeset} ->
        render(conn, "edit.html", person: person, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    person = Repo.get!(Person, id)
    Repo.delete!(person)

    conn
    |> put_flash(:info, "#{person.name} deleted!")
    |> redirect(to: admin_person_path(conn, :index))
  end

  defp smart_redirect(conn, _person, %{"close" => _true}) do
    redirect(conn, to: admin_person_path(conn, :index))
  end
  defp smart_redirect(conn, person, _params) do
    redirect(conn, to: admin_person_path(conn, :edit, person))
  end
end
