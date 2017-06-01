defmodule Ramoulade.Raml.Common do
  def get_required_scalar!(document, yaml, key) do
    value = get_scalar!(document, yaml, key)
    if value do
      value
    else
      Ramoulade.error!(document, "Missing value required for key: #{key}, at #{inspect(yaml)}")
    end
  end

  def get_string!(document, yaml, key) do
    case get_scalar!(document, yaml, key) do
      nil -> nil
      value when is_bitstring(value) -> value
      other -> Ramoulade.error!(document, "String value required for key: #{key}. Got #{inspect other}")
    end
  end

  @spec get_scalar!(struct, map, String.t) :: String.t | no_return
  def get_scalar!(document, yaml, key) do
    if is_map(yaml[key]) do
      if Map.has_key?(yaml[key], "value") do
        if is_nil_or_null(yaml[key]["value"]) do
          nil
        else
          yaml[key]["value"]
        end
      else
        Ramoulade.error!(document, "Scalar value required for key: #{key}. This can be provided as a map with a value key, or a single scalar value. Got #{inspect yaml[key]}")
      end
    else
      yaml[key]
    end
  end

  def get_list!(document, yaml, key, opts \\ []) do
    value = yaml[key]
    if is_nil_or_null(value) do
      nil
    else
      if is_list(value) do
        value
      else
        if opts[:wrap_scalar?] do
          if is_nil_or_null(value) do
            nil
          else
            [value]
          end
        else
          Ramoulade.error!(document, "List value required for key: #{key}, at #{inspect(yaml)}")
        end
      end
    end
  end

  def get_map!(document, yaml, key) do
    value = yaml[key]
    if is_nil_or_null(value) do
      %{}
    else
      if is_map(value) do
        value
      else
        Ramoulade.error!(document, "Map value required for key: #{key}, at #{inspect(yaml)}")
      end
    end
  end

  def is_nil_or_null(nil), do: true
  def is_nil_or_null(:null), do: true
  def is_nil_or_null(_), do: false
end
