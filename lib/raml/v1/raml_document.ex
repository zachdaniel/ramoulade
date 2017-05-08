defmodule Ramoulade.Raml.V1.RamlDocument do
  defstruct [:version, :type, :path, :contents]

  def parse!(yaml, path) do
    identifier = identifier(path)

    document = root_document_from_identifier(identifier, path)

    root = Ramoulade.Raml.V1.Root.from_yaml(document, yaml)

    %{document | contents: root}
  end

  def pre_parse_validate!(pre_processed_yaml, path) do
    yaml =
      if is_list(pre_processed_yaml) do
        Enum.into(pre_processed_yaml, %{})
      else
        pre_processed_yaml
      end
    identifier = identifier(path)

    if String.starts_with?(identifier, "#") do
      case identifier do
        "#%RAML 1.0" -> generic_document(yaml, path)
        _ -> raise "No document validator for #{identifier} at #{path}."
      end
    else
      generic_document(yaml, path)
    end
  end

  defp generic_document(yaml, _path) do
    yaml
  end

  defp root_document_from_identifier(identifier, path) do
    parts = String.split(identifier, " ")
    unless Enum.at(parts, 0) == "#%RAML" do
      raise "The first token of a raml document must be #%RAML. Got #{Enum.at(parts, 0)}."
    end

    version = String.trim_trailing(Enum.at(parts, 1) || "")

    unless version ==  "1.0" do
      raise "A valid raml version must immediately follow the #%RAML declaration. Got: #{Enum.at(parts, 1)}."
    end

    if Enum.count(parts) > 2 do
      "The #%RAML declaration and version must not be followed by anything but a newline. Got #{Enum.at(parts, 3)}."
    end

    %__MODULE__{
      version: 1.0,
      type: :root,
      path: path
    }
  end

  def identifier(path) do
    path
    |> File.stream!
    |> Enum.at(0)
    |> Kernel.||("")
    |> String.trim_trailing
  end
end
