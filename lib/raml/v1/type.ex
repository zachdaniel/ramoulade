defmodule Ramoulade.Raml.V1.Type do
  defstruct [
    :has_default?, :default, :inherits, :examples, :display_name, :description, :enum, :facets, :extra_facets, :name
  ]

  alias Ramoulade.Raml.Common

  @standard_facets ["default", "type", "examples", "example", "displayName", "description", "enum", "facets"]

  def from_yaml(yaml, root, name \\ nil) do
    if is_bitstring(yaml) do
      yaml
    else
      %__MODULE__{name: name}
      |> add_default(yaml, root)
      |> add_inherits(yaml, root)
      |> add_examples(yaml, root)
      |> add_display_name(yaml, root)
      |> add_description(yaml, root)
      |> add_enum(yaml, root)
      |> add_facets(yaml, root)
      |> add_extra_facets(yaml, root)
    end
  end

  #TODO: Define something like a `get_type()` in common
  def add_default(type, yaml, _root) do
    if yaml["default"] do
      %{type | default: yaml["default"], has_default?: true}
    else
      type
    end
  end

  def add_inherits(type, yaml, root) do
    if yaml["type"] do
      if is_map(yaml["type"]) do
        %{type | inherits: from_yaml(yaml["type"], root)}
      else
        %{type | inherits: yaml["type"]}
      end
    else
      if Common.get_map!(root.document, yaml, "properties") do
        %{type | inherits: from_yaml("object", root)}
      else
        %{type | inherits: from_yaml("inherits", root)}
      end
    end
  end

  defp add_examples(type, yaml, root) do
    if yaml["examples"] && yaml["example"] do
      Ramoulade.error!(root.document, "The `examples` and `example` facet must not be set together. At: #{inspect(yaml)}")
    end

    #TODO: get_type()!
    #TODO: Example types
    examples = List.wrap(yaml["examples"] || yaml["example"])

    %{type | examples: examples}
  end

  defp add_display_name(type, yaml, root) do
    display_name = Common.get_scalar!(root.document, yaml, "displayName")
    if display_name do
      %{type | display_name: display_name}
    else
      type
    end
  end

  defp add_description(type, yaml, root) do
    description = Common.get_scalar!(root.document, yaml, "description")
    if description do
      %{type | description: description}
    else
      type
    end
  end

  defp add_enum(type, yaml, root) do
    enum = Common.get_list!(root.document, yaml, "enum")
    if enum do
      %{type | enum: enum}
    else
      type
    end
  end

  def add_facets(type, yaml, root) do
    if yaml["facets"] do
      %{type | facets: Ramoulade.Raml.V1.Properties.from_yaml(yaml["facets"], root)}
    else
      type
    end
  end

  def add_extra_facets(type, yaml, _root) do
    %{type | extra_facets: Map.drop(yaml, @standard_facets)}
  end
end
