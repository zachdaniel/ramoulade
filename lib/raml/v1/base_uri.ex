defmodule Ramoulade.Raml.V1.BaseUri do
  defstruct [:uri, :uri_parameters]

  def from_parsed_yaml(yaml) do
    yaml
    |> validate
    |> new
  end

  def new(yaml) do
    if yaml["baseUri"] do
      uri_parameters = if yaml["baseUriParameters"] do
        Ramoulade.Raml.V1.Properties.from_parsed_yaml(yaml["baseUriParameters"])
      else
        nil
      end

      %__MODULE__{
        uri: yaml["baseUri"],
        uri_parameters: uri_parameters
      }
    else
      nil
    end
  end

  def validate(yaml) do
    if yaml["baseUriParameters"] && !yaml["baseUri"] do
      raise "baseUriParameters should only be set when baseUri is also set"
    else
      yaml
    end
  end
end
