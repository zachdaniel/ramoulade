defmodule Ramoulade.Raml.V1.SecuritySchemeDescribedBy do
  defstruct [:headers, :query_parameters, :query_string, :responses, :annotations]

  alias Ramoulade.Raml.Common

  def from_yaml(yaml, root) do
    %__MODULE__{}
    |> add_headers(yaml, root)
    |> add_query_string_or_parameters(yaml, root)
  end

  def add_headers(described_by, yaml, root) do
    if yaml["headers"] do
      headers = Ramoulade.Raml.V1.Properties.from_yaml(yaml["headers"], root.document)
      %{described_by | headers: headers}
    else
      described_by
    end
  end

  def add_query_string_or_parameters(described_by, yaml, root) do
    if yaml["queryParameters"] && yaml["queryString"] do
      Ramoulade.error!(root.document, "A security scheme described by node cannot have a queryString and queryParameters")
    end

    if yaml["queryParameters"] do
      map = Common.get_map!(root.document, yaml, "queryParameters")
      query_parameters = Ramoulade.Raml.V1.Properties.from_yaml(map, root)

      %{described_by | query_parameters: query_parameters}
    else
      if yaml["queryString"] do
        if is_bitstring(yaml["queryString"]) do
          %{described_by | query_string: yaml["queryString"]}
        else
          if is_map(yaml["queryString"]) do
            %{described_by | query_string: Ramoulade.Raml.V1.Type.from_yaml(yaml["queryString"], root)}
          else
            Ramoulade.error!(root.document, "Expected queryString value to be a map or a string. Got: #{yaml["queryString"]}")
          end
        end
      else
        described_by
      end
    end
  end

end
