class Admin::RolesController < Admin::BaseController
  before_filter :load_role, only: [:edit, :update, :destroy]

  def index
    @roles = Role.includes(:role_appointments, :current_people, :translations, organisations: [:translations]).
                  order("organisation_translations.name, roles.type DESC, roles.permanent_secretary DESC, role_translations.name")
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      redirect_to admin_roles_path, notice: %{"#{@role.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    if @role.update_attributes(role_params)
      redirect_to admin_roles_path, notice: %{"#{@role.name}" updated.}
    else
      render action: "edit"
    end
  end

  def destroy
    notice = %{"#{@role.name}" destroyed.}
    if @role.destroy
      redirect_to admin_roles_path, notice: notice
    else
      message = "Cannot destroy a role with appointments, organisations, or documents"
      redirect_to admin_roles_path, alert: message
    end
  end

  private

  def load_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(
      :name, :role_type, :whip_organisation_id, :role_payment_type_id,
      :attends_cabinet_type_id, :responsibilities,
      organisation_ids: [],
      worldwide_organisation_ids: []
    )
  end
end
