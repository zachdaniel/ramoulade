defmodule Ramoulade do
  @moduledoc """
  Documentation for Ramoulade.
  """

  @cr_agent Ramoulade.CircularReferenceChecker

  def parse_file(path) do
    Agent.start_link(fn -> [] end, name: @cr_agent)
    path
    |> _parse_file
    |> Ramoulade.Raml.V1.Parser.parse!
    # |> Ramoulade.Raml.V1.Root.from_parsed_yaml()
  after
    Agent.stop(@cr_agent)
  end

  @spec _parse_file(String.t) :: Ramoulade.Raml.V1.Root.parse_result
  def _parse_file(path) do
    with_path_context(path, fn absolute_path ->
      document = :yamerl_constr.file(
        absolute_path,
        detailed_constr: true,
        str_node_as_binary: true,
        node_mods: [Ramoulade.Raml.V1.IncludeTag]
      )
      |> List.last()

      [{:yamerl_doc, absolute_path, elem(document, 1)}]
    end)
  end

  @spec parse(String.t) :: Ramoulade.Raml.V1.Root.parse_result
  def parse(_text) do
    raise "Unimplemented."
  end

  defp with_path_context(path, func) do
    original_path = File.cwd!()
    try do
      file_path = Path.expand(path)

      push_to_file_stack!(file_path)

      file_path |> Path.dirname |> File.cd!

      func.(file_path)
    after
      pop_from_file_stack!()

      File.cd!(original_path)
    end
  end

  defp push_to_file_stack!(file_name) do
    _ = ensure_circular_reference_agent()
    Agent.update(@cr_agent, fn files ->
      if file_name in files do
        raise "Circular Reference Detected on file #{file_name}. Files loaded: #{inspect(files)}."
      else
        [file_name | files]
      end
    end)
  end

  defp pop_from_file_stack!() do
    Agent.update(@cr_agent, &tl/1)
  end

  defp ensure_circular_reference_agent() do
  end
end
