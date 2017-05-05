defmodule Ramoulade.Raml.Validations do
  def validate_type(yaml, key, :boolean) do
    if yaml[key] && is_boolean(yaml[key]) do
      yaml
    else
      raise "#{key} must be a boolean"
    end
  end

  def mutually_exclusive(yaml, left, right) do
    if !(yaml[left] && yaml[right]) do
      yaml
    else
      raise "#{left} and #{right} are mutually exclusive"
    end
  end

  def required(yaml, fields) when is_list(fields) do
    present_keys = yaml |> Map.keys |> MapSet.new
    required_keys = MapSet.new(fields)
    required_but_not_present = MapSet.difference(required_keys, present_keys)
    if MapSet.size(required_but_not_present) == 0 do
      yaml
    else
      raise "#{inspect(MapSet.to_list(required_but_not_present))} is/are required"
    end
  end
  def required(yaml, field) do
    if Map.has_key?(yaml, field) do
      yaml
    else
      raise "#{field} is required"
    end
  end
end
