defmodule Andromeda.Astrolog.Localizacao do
  @moduledoc false

  use Andromeda, type: :model, table: :localizacoes

  alias Andromeda.PathFinder.Planeta

  defstruct planeta: nil, quando: nil, piloto: nil

  def get_all_by_piloto(cert) do
    GenServer.call(__MODULE__, {:get, cert})
  end

  @required ~w(planeta piloto)a

  def create(params) do
    with {:ok, params} <- validate_required(params, @required),
         {:ok, params} <- validate_change(params, :planeta, &Planeta.valid_planeta?/1),
         {:ok, params} <- validate_change(params, :quando, &match?(%DateTime{}, &1)) do
          GenServer.cast(__MODULE__, {:create, params})
        end
  end

  @options [access: :read_write, ram_file: true]

  @impl true
  def init(:ok) do
    {:ok, ref} = :dets.open_file(@table, @options)
    {:ok, database: ref}
  end

  @impl true
  def handle_call({:get, cert}, _caller, database: ref) do
    query = {{{:_, :_, :"$1"}, :"$2"}, [{:==, :"$1", cert}], [:"$2"]}
    {:reply, :dets.select(ref, [query]), database: ref}
  end

  @impl true
  def handle_cast({:create, params}, database: ref) do
    params = Map.put_new(params, :quando, DateTime.utc_now())
    key = {params.planeta, params.quando, params.piloto}
    loc = struct(__MODULE__, params)
    :ok = :dets.insert(ref, {key, loc})
    {:noreply, database: ref}
  end
end
