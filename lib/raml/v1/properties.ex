defmodule Ramoulade.Raml.V1.Properties do
  defstruct properties: [], required: []

  def from_yaml(yaml, root) do
    Enum.reduce(yaml, %__MODULE__{}, &add_property(&1, &2, root))
  end

  defp add_property({property_name, type}, properties, _root) when is_bitstring(type) do
    properties
    |> maybe_set_required(type, String.ends_with?(type, "?"))
    |> Map.update!(:properties, fn properties ->
      Keyword.put(properties, String.to_atom(property_name), String.trim_trailing(type, "?"))
    end)
  end

  defp add_property({property_name, inline_type_declaration = %{"required" => required?}}, properties, root) do
    type = parse_inline_type(inline_type_declaration, root)

    properties
    |> maybe_set_required(property_name, required?)
    |> Map.update!(:properties, fn properties ->
      Keyword.put(properties, String.to_atom(property_name), type)
    end)
  end

  defp add_property({property_name, inline_type_declaration}, properties, root) do
    type = parse_inline_type(inline_type_declaration, root)

    properties
    |> maybe_set_required(property_name, !String.ends_with?(property_name, "?"))
    |> Map.update!(:properties, fn properties ->
      Keyword.put(properties, String.to_atom(property_name), type)
    end)
  end

  defp parse_inline_type(declaration, root) do
    declaration
    |> Map.delete("required")
    |> Ramoulade.Raml.V1.Type.from_yaml(root)
  end

  defp maybe_set_required(properties, key, required?) do
    if required? do
      Map.update!(properties, :required, fn required -> [key | required] end)
    else
      properties
    end
  end

end
