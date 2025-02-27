defmodule Core.Schema.Account do
  use Piazza.Ecto.Schema
  use Arc.Ecto.Schema
  alias Core.Schema.{User, DomainMapping, PlatformSubscription, Address}

  schema "accounts" do
    field :name,                 :string
    field :icon_id,              :binary_id
    field :workos_connection_id, :string
    field :icon,                 Core.Storage.Type
    field :billing_customer_id,  :string
    field :delinquent_at,        :utc_datetime_usec
    field :grandfathered_until,  :utc_datetime_usec
    field :user_count,           :integer, default: 0
    field :cluster_count,        :integer, default: 0
    field :usage_updated,        :boolean
    field :sa_provisioned,       :boolean
    field :address_updated,      :boolean, virtual: true
    field :trialed,              :boolean

    embeds_one :billing_address, Address, on_replace: :update

    belongs_to :root_user, User
    has_many :domain_mappings, DomainMapping, on_replace: :delete
    has_one :subscription, PlatformSubscription

    timestamps()
  end

  def usage_updated(query \\ __MODULE__) do
    from(a in query, where: a.usage_updated)
  end

  def dangling_root(query \\ __MODULE__) do
    from(a in query,
      join: u in assoc(a, :root_user),
      where: u.account_id != a.id
    )
  end

  def ordered(query \\ __MODULE__, order \\ [asc: :id]) do
    from(a in query, order_by: ^order)
  end

  def usage(query \\ __MODULE__) do
    from(a in query,
      left_join: u in Core.Schema.User, on: u.account_id == a.id,
      left_join: q in Core.Schema.UpgradeQueue, on: q.user_id == u.id,
      group_by: a.id,
      select: %{id: a.id, users: count(fragment("case when ? then null else ? end", u.service_account, u.id), :distinct), clusters: count(q.id, :distinct)}
    )
  end

  @valid ~w(name workos_connection_id sa_provisioned trialed)a
  @payment ~w(billing_customer_id delinquent_at)a

  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, @valid)
    |> cast_assoc(:domain_mappings)
    |> cast_embed(:billing_address)
    |> unique_constraint(:name)
    |> validate_required([:name])
    |> generate_uuid(:icon_id)
    |> cast_attachments(attrs, [:icon], allow_urls: true)
    |> set_address_updated()
  end


  def payment_changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, @payment)
  end

  defp set_address_updated(cs) do
    case get_change(cs, :billing_address) do
      nil -> cs
      _ -> put_change(cs, :address_updated, true)
    end
  end
end
