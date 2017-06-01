defmodule Ramoulade.Raml.V1.SecurityScheme do
  defstruct [:type, :display_name, :description, :described_by, :settings, :name]

  alias Ramoulade.Raml.Common

  @valid_types [
    "OAuth 1.0", "OAuth 2.0", "Basic Authentication",
    "Digest Authentication", "Pass Through"
  ]

  @custom_type ~r/x-.+/

  def from_yaml(yaml, root) do
    %__MODULE__{}
    |> add_type(yaml, root)
    |> add_display_name(yaml, root)
    |> add_description(yaml, root)
    |> add_settings(yaml, root)
    |> add_described_by(yaml, root)
  end

  def add_type(security_scheme, yaml, root) do
    type = Common.get_required_scalar!(root.document, yaml, "type")
    if type in @valid_types || String.match?(type, @custom_type) do
      %{security_scheme | type: type}
    else
      valid_type_string = Enum.join(@valid_types, ", ")
      Ramoulade.error!(root.document, "The type of a security scheme must be one of #{valid_type_string} or match the regex /x-.+/ .")
    end
  end

  def add_display_name(security_scheme, yaml, root) do
    display_name = Common.get_scalar!(root.document, yaml, "displayName")
    %{security_scheme | display_name: display_name}
  end

  def add_description(security_scheme, yaml, root) do
    description = Common.get_scalar!(root.document, yaml, "description")
    %{security_scheme | description: description}
  end

  def add_settings(security_scheme, yaml, root) do
    settings = Common.get_map!(root.document, yaml, "settings")
    %{security_scheme | settings: settings}
  end

  def add_described_by(security_scheme, yaml, root) do
    if yaml["describedBy"] do
      described_by = Ramoulade.Raml.V1.SecuritySchemeDescribedBy.from_yaml(yaml["describedBy"], root)
      %{security_scheme | described_by: described_by}
    else
      security_scheme
    end
  end
end
