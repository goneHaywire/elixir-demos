defmodule KV do
  use Application
  @moduledoc """
  Documentation for `KV`.
  """
  
  @impl true
  def start(_type, _args) do
    KV.Supervisor.start_link(name: Supervisor)
  end
end
