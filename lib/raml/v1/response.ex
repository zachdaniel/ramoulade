defmodule Ramoulade.Raml.V1.Response do
  defstruct [:description, :annotations, :headers, :body]

  alias Ramoulade.Raml.Common

  def from_yaml(yaml, root) do
    %__MODULE__{}
    |> add_description(yaml, root)
    |> add_headers(yaml, root)
    |> add_body(yaml, root)
  end

  def add_description(response, yaml, root) do
    %{response | description: Common.get_scalar!(root.document, yaml, "description")}
  end

  def add_headers(response, yaml, root) do
    if yaml["headers"] do
      headers = Ramoulade.Raml.V1.Properties.from_yaml(yaml["headers"], root.document)
      %{response | headers: headers}
    else
      response
    end
  end

  def add_body(response, yaml, _root) do
    if yaml["body"] do
      # body = Ramoulade.Raml.V1.Body.from_yaml(yaml[""])
      response
    else
      response
    end
  end

end
