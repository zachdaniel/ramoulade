defmodule Ramoulade do
  @moduledoc """
  Documentation for Ramoulade.
  """

  @cr_agent Ramoulade.CircularReferenceChecker

  def parse_file(path) do
    Agent.start_link(fn -> [] end, name: @cr_agent)
    path
    |> _parse_file()
    |> deep_to_map
    |> Ramoulade.Raml.V1.RamlDocument.parse!(path)
  after
    Agent.stop(@cr_agent)
  end

  def _parse_file(path) do
    with_path_context(path, fn absolute_path ->
      :yamerl_constr.file(
        absolute_path,
        detailed_constr: false,
        str_node_as_binary: true,
        node_mods: [Ramoulade.Raml.V1.IncludeTag]
      )
      |> List.last()
      |> Ramoulade.Raml.V1.RamlDocument.pre_parse_validate!(absolute_path)
    end)
  end

  def parse(_text) do
    raise "Unimplemented."
  end

  def error!(document, errors) when is_list(errors) do
    message =
      errors
      |> Enum.map(&"#{document.path}: #{&1}")
      |> Enum.join("\n")

    "\n\n" <> message <> "\n\n"
  end

  def error!(document, error) do
    raise "\n\n#{document.path}: #{error}\n\n"
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

  defp deep_to_map(yaml) when is_map(yaml) do
    yaml
    |> Map.to_list()
    |> deep_to_map
  end

  defp deep_to_map(yaml) when is_list(yaml) do
    if Enum.all?(yaml, &is_tuple/1) do
      yaml
      |> Enum.map(&deep_to_map/1)
      |> Enum.into(%{})
    else
      yaml
      |> Enum.map(&deep_to_map/1)
    end
  end

  defp deep_to_map({key, value}), do: {key, deep_to_map(value)}

  defp deep_to_map(other), do: other
end
