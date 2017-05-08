defmodule Ramoulade.Raml.V1.Properties do
  defstruct properties: %{}, required: []

  def from_parsed_yaml(yaml) do
    yaml
    |> validate
    |> new
  end

  def new(yaml) do
    Enum.reduce(yaml, %__MODULE__{}, &add_property/2)
  end

  def validate(yaml) do
    yaml
  end

  defp add_property({property_name, %{"type" => type, "required" => true}}, properties) do
    properties
    |> Map.update!(:properties, &Map.put(&1, property_name, type))
  end

  defp add_property({property_name, %{"type" => type}}, properties) do
    if String.ends_with?(property_name, "?") do
      Map.update!(properties, :properties, &Map.put(&1, property_name, type))
    else
      properties
      |> Map.update!(:properties, &Map.put(&1, property_name, type))
      |> Map.update!(:required, fn required -> [property_name | required] end)
    end
  end

end
