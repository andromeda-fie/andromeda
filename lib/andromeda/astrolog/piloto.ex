defmodule Andromeda.Astrolog.Piloto do
  use Andromeda, type: :model, table: :pilotos

  alias Andromeda.Astrolog
  alias Andromeda.Astrolog.Localizacao

  defstruct nome: nil, certificacao: nil, localizacoes: [], idade: nil, creditos: 500

  def get_all do
    GenServer.call(__MODULE__, :list)
  end

  def get_by_certificacao(cert) do
    GenServer.call(__MODULE__, {:get, cert})
  end

  def create(params) do
    with {:ok, params} <- changeset(params) do
      GenServer.cast(__MODULE__, {:create, params})      
    end
  end

  def update(cert, params) do
    with {:ok, params} <- update_changeset(params) do
      GenServer.call(__MODULE__, {:update, cert, params})
    end
  end

  @required ~w(nome certificacao idade)a

  defp changeset(params) do
    with {:ok, params} <- validate_required(params, @required),
         {:ok, params} <- validate_change(params, :certificacao, &Astrolog.validate_certification/1) do
      validate_change(params, :idade, &Kernel.>=(&1, 20))
    end
  end

  defp update_changeset(params) do
    validate_change(params, :idade, &Kernel.>=(&1, 20))
  end

  @options [access: :read_write, ram_file: true]

  @impl true
  def init(:ok) do
    {:ok, ref} = :dets.open_file(@table, @options)
    {:ok, database: ref}
  end

  @impl true
  def handle_call(:list, _caller, database: ref) do
    query = {{:_, :"$1"}, [], [:"$1"]}

    {:reply,
      ref
      |> :dets.select([query])
      |> Enum.map(&preload_loc/1), database: ref}
  end

  def handle_call({:get, cert}, _caller, database: ref) do
    query = {{cert, :"$1"}, [], [:"$1"]}

    case :dets.select(ref, [query]) do
      [] -> {:reply, nil, database: ref} 
      [piloto] -> {:reply, preload_loc(piloto), database: ref}
    end
  end

  def handle_call({:update, cert, params}, _caller, database: ref) do
    query = {{cert, :"$1"}, [], [:"$1"]}

    case :dets.select(ref, [query]) do
      [] ->
        {:reply, nil, database: ref} 

      [piloto] ->
        piloto = Map.merge(piloto, Map.drop(params, [:certificacao]))
        key = piloto.certificacao
        :ok = :dets.insert(ref, {key, piloto})
        {:reply, preload_loc(piloto), database: ref}
    end
  end

  @impl true
  def handle_cast({:create, params}, database: ref) do
    key = params.certificacao
  	piloto = struct(__MODULE__, params)
  	:ok = :dets.insert(ref, {key, piloto})
  	{:noreply, database: ref}
  end
  
  defp preload_loc(%__MODULE__{certificacao: cert} = piloto) do
    loc = Localizacao.get_all_by_piloto(cert)
    %{piloto | localizacoes: loc}
  end
end
