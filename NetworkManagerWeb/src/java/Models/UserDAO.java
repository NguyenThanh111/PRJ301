
package Models;

import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;


public class UserDAO implements IDAO<UserDTO, Integer>{
    
    private UserDTO mapRow(ResultSet rs) throws SQLException {
        return new UserDTO(
                rs.getInt("user_id"),
                rs.getString("username"),
                rs.getString("password"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("role"),
                rs.getBoolean("status")
        );
    }

    @Override
    public boolean insert(UserDTO t) {
        String sql = "INSERT INTO [user] "
                + "(user_id, username, password, full_name, email, role, status) "
                + "VALUES (?,?,?,?,?,?,?)";
        
        try{
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setInt(1, t.getUserId());
            ps.setString(2, t.getUserName());
            ps.setString(3, t.getPassword());
            ps.setString(4, t.getFullName());
            ps.setString(5, t.getEmail());
            ps.setString(6, t.getRole());
            ps.setBoolean(7, t.isStatus());
            
            return ps.executeUpdate() > 0;
        }catch(Exception e){
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(UserDTO t) {
        String sql = "UPDATE [user] SET "
                + "username = ?, password = ?, full_name = ?, "
                + "email = ?, role = ?, status = ? "
                + "WHERE user_id = ?";
        try{
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            
            ps.setString(1, t.getUserName());
            ps.setString(2, t.getPassword());
            ps.setString(3, t.getFullName());
            ps.setString(4, t.getEmail());
            ps.setString(5, t.getRole());
            ps.setBoolean(6, t.isStatus());
            ps.setInt(7, t.getUserId());
            
            return ps.executeUpdate() > 0;
            
        }catch(Exception e){
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean remove(UserDTO t) {
        return softDelete(t.getUserId());
    }

    //================= Duyet toan bo User ======================
    @Override
    public ArrayList<UserDTO> ListAll() {
        ArrayList<UserDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM [user]";
        try{
            Connection connect = DbUtils.getConnection();
            Statement st = connect.createStatement();
            ResultSet rs = st.executeQuery(sql); //lay du lieu tu Table [user]
            
            while(rs.next()){ //duyet qua tung dong trong table
                list.add(mapRow(rs)); //add thong tin tung dong vao list
                        //mapRow la chuyen doi du lieu tu table thanh Object
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        return list;
    }
    
    //================= Tim kiem User bang ID =====================
    @Override
    public UserDTO searchById(Integer id) {
        String sql = "SELECT * FROM [user] WHERE user_id=?";
        System.out.println(sql);
        try {
            Connection conn = DbUtils.getConnection();
            //Statement st = conn.createStatement();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            // Da lay duoc du lieu tu Table User
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    //============ Tim kiem bang username ===================
    public UserDTO searchByNameOrEmail(String input) {
        String sql = "SELECT * FROM [user] WHERE (username = ? OR email = ?)";
        System.out.println(sql);
        try {
            Connection conn = DbUtils.getConnection();
            //Statement st = conn.createStatement();
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, input);
            pst.setString(2, input);
            ResultSet rs = pst.executeQuery();
            // Da lay duoc du lieu tu Table User
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    //================ Kiem tra login =======================
    public boolean checklogin(String username, String password){
        UserDTO user = searchByNameOrEmail(username);
        if(user == null){
            return false;
        }
        if(!user.isStatus()){ //neu status = 0
            return false;
        }
        if(!user.getPassword().equals(password)){ //neu password khong dung
            return false;
        }
        return true;
    }
    
    //================= Xoa User (Doi Status thanh invalid) =============
    public boolean softDelete(int userID) {
        String sql = "UPDATE [user] SET status = 0 WHERE user_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userID);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    
    
}