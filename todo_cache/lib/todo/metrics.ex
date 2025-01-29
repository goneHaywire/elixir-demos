defmodule Todo.Metrics do
  use Task

  @metrics_interval_seconds 10

  def start_link(_) do
    IO.puts("Starting Metrics Task (#{@metrics_interval_seconds}s)")
    Task.Supervisor.start_link(name: MyTaskSupervisor)
    Task.Supervisor.start_child(
      MyTaskSupervisor,
      &loop/0
    )
  end

  defp loop() do
    Process.sleep(:timer.seconds(@metrics_interval_seconds))
    IO.inspect("Metrics: #{inspect(collect_metrics())}")
    loop()
  end

  defp collect_metrics() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count),
    ]
  end

end
