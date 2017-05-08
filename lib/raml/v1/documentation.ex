defmodule Ramoulade.Raml.V1.Documentation do
  defstruct [:title, :content]

  def from_yaml(yaml, document) do
    for doc_yaml <- yaml do
      doc_yaml
      |> validate(document)
      |> new
    end
  end

  def new(yaml) do
    %__MODULE__{
      title: yaml["title"],
      content: yaml["content"]
    }
  end

  def validate(yaml, document) do
    unless yaml["title"] do
      Ramoulade.error!(document, "A documentation section MUST have a title attribute.")
    end

    unless yaml["content"] do
      Ramoulade.error!(document, "A documentation section MUST have a content attribute.")
    end

    yaml
  end
end
