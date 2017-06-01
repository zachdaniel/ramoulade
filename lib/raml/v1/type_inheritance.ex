defmodule Ramoulade.Raml.V1.TypeInheritance do
  defstruct [:parents, :name]

  def from_types(types) do
    initial_types = initial_tree()

    Enum.map(types, fn {_name, type} ->
      IO.inspect(type, label: :type)
    end)

    initial_types
  end

  defp initial_tree() do
    %{
      "time-only" => new("time-only"),
      "datetime" => new("datetime"),
      "datetime-only" => new("datetime-only"),
      "date-only" => new("date-only"),
      "number" => new("number"),
      "boolean" => new("boolean"),
      "string" => new("string"),
      "null" => new("null"),
      "file" => new("file"),
      "array" => new("array"),
      "object" => new("object"),
      "union" => new("union"),
      "XSD Schema" => new("XSD Schema"),
      "JSON Schema" => new("JSON Schema")
    }
    |> inherit("integer", "number")
  end

  defp new(name, parents \\ [:any]) do
    %__MODULE__{name: name, parents: parents}
  end

  defp inherit(types, name, parent_or_parents) do
    parents = List.wrap(parent_or_parents)

    parent_types = Enum.map(parents, &Map.get(types, &1))

    Map.put(types, name, new(name, parent_types))
  end
end
