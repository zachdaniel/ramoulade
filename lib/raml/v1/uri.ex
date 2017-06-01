defmodule Ramoulade.Raml.V1.Uri do
  defstruct [:uri_template, :uri, :uri_parameters]

  def from_yaml(base_uri, root, uri_parameters) do
    if uri_parameters do
      %__MODULE__{
        uri: base_uri,
        uri_template: UriTemplate.from_string(base_uri),
        uri_parameters: Ramoulade.Raml.V1.Properties.from_yaml(uri_parameters, root)
      }
    else
      %__MODULE__{
        uri: base_uri,
        uri_template: UriTemplate.from_string(base_uri)
      }
    end
  end
end
