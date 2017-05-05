defmodule Ramoulade.Raml.V1.Documentation do
  defstruct [:title, :content]

  alias Ramoulade.Raml.Validations

  @spec from_parsed_yaml(map) :: Ramoulade.Raml.V1.Root.parse_result(%__MODULE__{})
  def from_parsed_yaml(yaml) do
    for doc_yaml <- Map.get(yaml, "documentation", []) do
      doc_yaml
      |> validate
      |> new
    end
  end

  def new(yaml) do
    %__MODULE__{
      title: yaml["title"],
      content: yaml["content"]
    }
  end

  def validate(yaml) do
    yaml
    |> Validations.required(["title", "content"])
  end
end
