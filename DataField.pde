class DataField {
  
  String  m_description;
  char    m_type;           // 'F' float, 'I' int, 'S' string
  boolean m_bTarget;
  boolean m_bIgnore;
  float   m_fMin;
  float   m_fMax;
  int     m_iMin;
  int     m_iMax;
  
  DataField() {
    setDefaults();
  }
  
  DataField(String desc, char type) {
    setDefaults();
    m_description = desc;
    m_type = type;
  }  
  
  DataField(String desc, char type, boolean target) {
    setDefaults();
    m_description = desc;
    m_type = type;
    m_bTarget = target;
  }  
  
  DataField(String desc, char type, boolean target, boolean ignore) {
    setDefaults();    
    m_description = desc;
    m_type = type;
    m_bTarget = target;
    m_bIgnore = ignore;
  }
  
  void setDefaults() {
    m_type = 'F';
    m_bTarget = false;
    m_bIgnore = false;
    m_fMin = 0.0;
    m_fMax = 0.0;
    m_iMin = 0;
    m_iMax = 0;    
  }
  
  boolean isActiveInput() {
    return ((!m_bTarget) && (!m_bIgnore));
  }
  
  boolean isInt() {
    return (m_type == 'I');
  }
  
  boolean isFloat() {
    return (m_type == 'F');
  }

}
