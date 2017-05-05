defmodule Ramoulade.Raml.V1.Parser do
  def parse!(expanded_yaml) do
    parse_result = parse_node(expanded_yaml, %{parsed: nil, errors: [], path: ""})

    if Enum.empty?(parse_result.errors) do
      parse_result.parsed
    else
      raise format_errors(parse_result.errors)
    end
  end

  def parse_node(node, context)
  def parse_node(nodes, context) when is_list(nodes), do: Enum.reduce(nodes, context, &parse_node(&1, &2))
  def parse_node({:yamerl_doc, doc_path, document}, context) do
    parse_node(document, %{context | path: doc_path})
  end

  def parse_node({:yamerl_map, :yamerl_node_map, _tag, _location, content}, context) do
    parse_node(content, context)
  end

  def parse_node(node, context) do
    add_error(
      context,
      %{
        message: "No validation handler for node: #{inspect(node)}"
      }
    )
  end

  defp identifier(path) do
    path
    |> File.stream!()
    |> Enum.at(0)
  end

  defp add_error(context = %{errors: errors}, error) do
    %{context | errors: [error | errors]}
  end

  defp format_errors(errors) do
    errors
    |> Enum.map(&single_line_error/1)
    |> Enum.join("\n")
  end

  defp single_line_error(error) do
    "#{error[:path]}#{detailed_info(error)} -> #{truncate(error[:message])}"
  end

  defp detailed_info(%{line: line, column: column}) do
    ":#{line} (c#{column})"
  end
  defp detailed_info(_), do: ""

  defp truncate(string) do
    string
    |> Kernel.||("")
    |> String.split_at(200)
    |> elem(0)
    |> Kernel.<>("...(truncated)")
  end
end
