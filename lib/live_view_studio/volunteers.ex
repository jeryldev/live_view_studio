defmodule LiveViewStudio.Volunteers do
  @moduledoc """
  The Volunteers context.
  """

  import Ecto.Query, warn: false
  alias LiveViewStudio.Repo

  alias LiveViewStudio.Volunteers.Volunteer

  @topic inspect(__MODULE__)
  @pubsub LiveViewStudio.PubSub

  @doc """
  Returns the list of volunteers.

  ## Examples

      iex> list_volunteers()
      [%Volunteer{}, ...]

  """
  def list_volunteers do
    Repo.all(from v in Volunteer, order_by: [desc: v.id])
  end

  @doc """
  Gets a single volunteer.

  Raises `Ecto.NoResultsError` if the Volunteer does not exist.

  ## Examples

      iex> get_volunteer!(123)
      %Volunteer{}

      iex> get_volunteer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_volunteer!(id), do: Repo.get!(Volunteer, id)

  @doc """
  Creates a volunteer.

  ## Examples

      iex> create_volunteer(%{field: value})
      {:ok, %Volunteer{}}

      iex> create_volunteer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_volunteer(attrs \\ %{}) do
    %Volunteer{}
    |> Volunteer.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:volunteer_created)
  end

  @doc """
  Updates a volunteer.

  ## Examples

      iex> update_volunteer(volunteer, %{field: new_value})
      {:ok, %Volunteer{}}

      iex> update_volunteer(volunteer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_volunteer(%Volunteer{} = volunteer, attrs) do
    volunteer
    |> Volunteer.changeset(attrs)
    |> Repo.update()
    |> broadcast(:volunteer_updated)
  end

  @doc """
  Deletes a volunteer.

  ## Examples

      iex> delete_volunteer(volunteer)
      {:ok, %Volunteer{}}

      iex> delete_volunteer(volunteer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_volunteer(%Volunteer{} = volunteer) do
    volunteer
    |> Repo.delete()
    |> broadcast(:volunteer_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking volunteer changes.

  ## Examples

      iex> change_volunteer(volunteer)
      %Ecto.Changeset{data: %Volunteer{}}

  """
  def change_volunteer(%Volunteer{} = volunteer, attrs \\ %{}) do
    Volunteer.changeset(volunteer, attrs)
  end

  @doc """
  Updates the checked out status of a volunteer.

  ## Examples

      iex> toggle_status_volunteer(volunteer)
      {:ok, %Volunteer{}}
  """
  def toggle_status_volunteer(%Volunteer{} = volunteer) do
    update_volunteer(volunteer, %{checked_out: !volunteer.checked_out})
  end

  @doc """
  Subscribe to volunteers topic PubSub

  ## Examples

      iex> subscribe()
      :ok

  """
  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  @doc """
  Broadcast message to volunteers pubsub subscribers. Returns the volunteer or the error.

  ## Examples

      iex> broadcast({:ok, volunteer}, :volunteer_created)
      {:ok, %Volunteer{}}

      iex> broadcast({:error, %Ecto.Changeset{}}, :volunteer_created)
      {:error, %Ecto.Changeset{}}

  """
  def broadcast({:ok, volunteer}, tag) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {tag, volunteer})
    {:ok, volunteer}
  end

  def broadcast({:error, _changeset} = error, _tag), do: error
end
