defmodule Andromeda.PathFinder.Planeta do
  @moduledoc false

  use Andromeda, type: :model, table: :planetas

  defstruct [:nome]

  # Client API

  def get_all do
    GenServer.call(__MODULE__, :list)
  end

  def valid_planeta?(name) do
    Enum.any?(get_all(), &(to_string(&1.nome) == to_string(name)))
  end

  # Server API

  @options [access: :read_write, ram_file: true]

  @impl true
  def init(:ok) do
    {:ok, ref} = :dets.open_file(@table, @options)
    {:ok, [database: ref], {:continue, :bootstrap}}
  end

  @planetas [
    %{nome: "prime"},
    %{nome: "galaxara"},
    %{nome: "androthar"},
    %{nome: "nebulon"},
    %{nome: "andarion"},
    %{nome: "helion"},
  ]

  @impl true
  def handle_continue(:bootstrap, database: ref) do
    for planeta <- @planetas do
      key = planeta.nome
      value = struct(__MODULE__, planeta)
      :ok = :dets.insert(ref, {key, value})
    end

    {:noreply, database: ref}
  end

  @impl true
  def handle_call(:list, _caller, database: ref) do
    query = {{:_, :"$1"}, [], [:"$1"]}
    {:reply, :dets.select(ref, [query]), database: ref}
  end
end
