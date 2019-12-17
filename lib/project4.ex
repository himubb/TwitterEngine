defmodule Project4 do
	use Application

	def start(_type,_args) do
		import Supervisor.Spec


	  :ets.new(:users, [:set, :public, :named_table])
      :ets.new(:register_user, [:set, :public, :named_table])
      :ets.new(:tweets_by_user, [:set, :public, :named_table])
      :ets.new(:hashtag_table, [:set, :public, :named_table])
      :ets.new(:mention_table, [:set, :public, :named_table])
      :ets.new(:subscriptions, [:set, :public, :named_table])
      :ets.new(:user_followers, [:set, :public, :named_table])
      :ets.insert(:users, {"clients", []})

      children = [
      supervisor(Project4Web.Endpoint, []),
    ]


    opts = [strategy: :one_for_one, name: Project4.Supervisor]
    Supervisor.start_link(children, opts)

  end

  def config_change(changed, _new, removed) do
    Project4Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
